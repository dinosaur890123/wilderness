module Admin
  class AuditController < BaseController
    def index
        render inertia: "admin/audit", props:{
            events: scoped_events.map {|event| event_props(event)},
            category: category,
            categories: AuditEvent::CATEGORIES.keys,
        }
    end

    private
    def category
        AuditEvent::CATEGORIES.key?(params[:category])? params[:category]: ""
    end
    def scoped_events
      scope = AuditEvent.includes(:actor, :target_user, :subject).recent.limit(200)
      category.present? ? scope.in_category(category): scope
    end

    def event_props(event)
      {
        id: event.id,
        action: event.action,
        actor: event.actor&.display_name || "System",
        actor_id: event.actor_id,
        target: event.target_user&.display_name,
        target_id: event.target_user_id,
        subject: event.subject_label,
        metadata: event.metadata,
        created_at: event.created_at
      }
    end
  end
end


