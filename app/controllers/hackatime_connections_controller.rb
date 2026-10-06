class HackatimeConnectionsController < ApplicationController
    before_action :require_authentication

    AUTHORISE_URL = "https://hackatime.hackclub.com/oauth/authorize".freeze
    SCOPES = "profile read".freeze

    def create
    state = SecureRandom.hex(24)
    session[:hackatime_state] = state

    redirect_to("#{AUTHORISE_URL}?#{{
        client_id: ENV.fetch('HACKATIME_CLIENT_ID'),
        redirect_uri: hackatime_callback_url,
        response_type: 'code',
        scope: SCOPES,
        state: state
    }.to_query}", allow_other_host: true)
    end

    def callback
        expected = session.delete(:hackatime_state)
        return fail_with("error from hackatime") if expected.blank? || params[:state] != expected
        return fail_with(params[:error_description] || params[:error]) if params[:error].present?

        Hackatime::Connection.new(current_user).complete!(
            code: params[:code],
            redirect_uri: hackatime_callback_url
        )
        AuditEvent.record!("hackatime.connected", actor: current_user, subject: current_user)
        redirect_to camp_path, notice: "hackatime connected successfullly"
    end

    def destroy
        Hackatime::Connection.new(current_user).revoke!
        AuditEvent.record!("hackatime.disconnected", actor: current_user, subject: current_user)
        redirect_to camp_path, notice: "hackatime disconnected"
    end
    private
    def fail_with(message)
        redirect_to camp_path, alert: {
            title: "couldn't connect hackatime",
            description: message.to_s,
            iconName: "CircleAlert",
            variant: "warning"
    }
end
end
