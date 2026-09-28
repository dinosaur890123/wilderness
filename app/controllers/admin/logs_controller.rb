module Admin
    class LogsController < BaseController
        def create
            user = User.find(params[:user_id])
            amount = params[:amount].to_i
            memo = params[:memo].to_s.strip

            if amount.zero?
                return redirect_to admin_user_path(user), inertia: {errors: {amount: "Enter an amount other than zero." } }
            end
            if memo.blank?
                return redirect_to admin_user_path(user), inertia: {errors: {memo: "Add a note explaining why you made a change."}}
            end

            entry = LogTransaction.create!(user: user, amount: amount, source: "adjustment", memo: memo)
            AuditEvent.record!(
                amount.positive? ? "logs.granted": "logs.removed",
                actor: current_user, subject: entry, target_user: user, amount: amount, note: memo
            )
            notice = amount.positive? ? "Granted #{amount} logs to #{user.display_name}." : "Removed #{amount.abs} logs from #{user.display_name}."
            redirect_to admin_user_path(user), notice: notice
    end
  end
end