module Admin
  class UsersController < BaseController
    def index
      render inertia: "admin/users", props: {
        users: scoped_users.map {|user| user_props(user)},
        query: params[:q].to_s,
        flash_notice: flash_notice
      }
    end

    def show
      user = User.find(params[:id])
      render inertia: "admin/user", props: {
        camper: user_props(user).merge(
          balance: user.logs_balance,
          region: user.region,
          hackatime_connected: user.hackatime_connected?,
          hackatime_synced_at: user.hackatime_synced_at,
          streak: user.streak,
          fire_state: user.fire_state
      ),
      projects: user.projects.order(:plot_index).map {|project| project_props(project)},
      transactions: user.log_transactions.recent.limit(50).map {|entry| entry_props(entry)},
      flash_notice: flash_notice
    }
  end

    def update
      user = User.find(params[:id])

      case params[:field]
      when "admin"
        if user == current_user
          return redirect_back fallback_location: admin_users_path, notice: "You cannot remove your own admin access."
        end
        user.update!(admin: !user.admin?)
        AuditEvent.record!(user.admin? ? "user.admin_granted" : "user.admin_revoked", actor: current_user, subject: user)
        notice = user.admin? ? "#{user.display_name} is now an admin." : "#{user.display_name} is no longer an admin."
      when "camp_access"
        if camp_actors.include?(user.flipper_id)
          Flipper.disable_actor(:camp, user)
          AuditEvent.record!("user.camp_revoked", actor: current_user, subject: user)
          notice = "Revoked the invite for #{user.display_name}."
        else
          Flipper.enable_actor(:camp, user)
          AuditEvent.record!("user.camp_invited", actor: current_user, subject: user)
          notice = "Invited #{user.display_name} to wilderness."
        end
      end

      redirect_back fallback_location: admin_users_path, notice: notice
    end

    private

    def scoped_users
      scope = User.order(Arel.sql("rsvped_at DESC NULLS LAST")).limit(100)
      query = params[:q].to_s.strip
      return scope if query.blank?
      scope.where(
        "users.name ILIKE :q OR users.email ILIKE :q OR users.slack_id ILIKE :q",
        q: "%#{query}%"
      )
    end

    def project_counts
      @project_counts ||= Project.group(:user_id).count
    end

    def user_props(user)
      {
        id: user.id,
        name: user.display_name,
        email: user.email,
        slack_id: user.slack_id,
        verification_status: user.verification_status,
        admin: user.admin?,
        camp_access: access?(user),
        actor_enabled: camp_actors.include?(user.flipper_id),
        rsvped_at: user.rsvped_at,
        projects_count: project_counts.fetch(user.id, 0)
      }
  end

  def project_props(project)
    {
      id: project.id,
      name: project.name,
      status: project.status,
      hours: project.hours.round(1),
      project_tier: project.project_tier,
      repo_url: project.repo_url,
      demo_url: project.demo_url
    }
  end

  def entry_props(entry)
      {
        id: entry.id,
        amount: entry.amount,
        source: entry.source,
        memo: entry.memo,
        created_at: entry.created_at
      }
    end
  end
end
