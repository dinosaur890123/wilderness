class AuditEvent < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :target_user, class_name: "User", optional: true
  belongs_to :subject, polymorphic: true, optional: true

   CATEGORIES = {
    "admin" => %w[user.admin_granted user.admin_revoked user.camp_invited user.camp_revoked flag.enabled flag.disabled],
    "logs" => %w[logs.granted logs.removed logs.awarded],
    "projects" => %w[project.created project.updated project.shipped project.approved],
    "shop" => %w[shop_item.created shop_item.updated shop_item.deleted],
    "account" => %w[hackatime.connected hackatime.disconnected]
  }.freeze

  ACTIONS = CATEGORIES.values.flatten.freeze

  scope :recent, -> { order(created_at: :desc) }
  scope :in_category, ->(category) { where(action: CATEGORIES.fetch(category, [])) }

  def self.record!(action, actor: nil, subject: nil, target_user: nil, **metadata)
    create!(
      action: action,
      actor: actor,
      subject: subject,
      target_user: target_user || subject_owner(subject),
      metadata: metadata
    )
  end

  def self.subject_owner(subject)
    subject.is_a?(User)? subject: subject.try(:user)
  end
  private_class_method :subject_owner

  def subject_label
    case subject
    when User then subject.display_name
    when Project then subject.name
    when ShopItem then subject.title
    end
  end
end