module Admin
  class OverviewController < BaseController
    def index
      render inertia: "admin/overview", props: {
        stats: {
          rsvps: User.rsvped.count,
          with_access: User.select { |user| access?(user) }.size,
          admins: User.where(admin: true).count,
          projects: Project.count,
          shipped: Project.where(status: "shipped").count,
          hours: (Project.sum(:hackatime_seconds).to_f / 3600).round
        },
          log_totals: {
          circulating: LogTransaction.sum(:amount),
          granted: LogTransaction.grants.where("amount > 0").sum(:amount),
          spent: -LogTransaction.where("amount < 0").sum(:amount)
        },
        camp_open: camp_open?,
        recent: User.rsvped.order(rsvped_at: :desc).limit(8).map {|user|
          {
            id: user.id,
            name: user.display_name,
            email: user.email,
            rsvped_at: user.rsvped_at
          }
        },
        flash_notice: flash_notice
      }
    end
  end
end
