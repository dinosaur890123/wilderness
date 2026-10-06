class ShipSubmission < ApplicationRecord
    belongs_to :project
    belongs_to :reviewer, class_name: "User", optional: true
    has_one :log_transaction, as: :sourceable

    STATUSES = %w[pending approved changes_requested].freeze
    validates :status, inclusion: { in: STATUSES }

    def submitted_hours = submitted_seconds.to_f/3600
    def payable_seconds = [ submitted_seconds - project.paid_seconds, 0 ].max
    def payable_logs = (payable_seconds.to_f/3600* rate).round

    def approve!(reviewer:, notes: nil)
        return false unless status == "pending"

        transaction do
            awarded = payable_logs

            LogTransaction.create!(
                user: project.user, amount: awarded, source: "ship_submission", sourceable: self, memo: "#{project.name} approved"
            )

            project.update!(paid_seconds: submitted_seconds, status: "approved")

            update!(status: "approved", reviewer: reviewer, review_notes: notes, reviewed_at: Time.current)
            AuditEvent.record!("project.approved", actor: reviewer, subject: project, name: project.name)
            AuditEvent.record!("logs.awarded", actor: reviewer, subject: project, target_user: project.user, amount: awarded)
        end
        true
    rescue ActiveRecord::RecordNotUnique
        false
    end

    def request_changes!(reviewer:, notes:)
        return false
        transaction do
            project.update!(status: "changes_requested")
            update!(status: "changes_requested", reviewer:, review_notes: notes, reviewed_at: Time.current)
        end
        true
    end
end
