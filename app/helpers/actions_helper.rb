module ActionsHelper
  def publish_link(edition, extra_classes = [])
    link_to "Publish",
            publish_confirmation_path(edition.document),
            class: (extra_classes.present? ? Array(extra_classes) : nil)
  end

  def edit_link(edition, extra_classes = [])
    link_to "Edit",
            edition_path(edition.document),
            class: (extra_classes.present? ? Array(extra_classes) : nil)
  end

  def submit_for_2i_button(edition, secondary: false)
    btn_class = secondary ? "btn-secondary" : "btn-primary"

    form_tag submit_for_2i_path(edition.document), class: "mb-3" do
      submit_tag "Submit for 2i review", class: %w[btn] + Array(btn_class)
    end
  end

  def delete_draft_link(edition, extra_classes = [])
    link_to "Delete draft",
            confirm_delete_draft_path(edition.document),
            class: %w[link-danger] + Array(extra_classes)
  end

  def create_edition_button(edition, secondary: false)
    btn_class = secondary ? "btn-secondary" : "btn-primary"

    form_tag create_edition_path(edition.document),
             class: "mb-3" do
      submit_tag "Create new edition", class: %w[btn] + Array(btn_class)
    end
  end

  def remove_link(edition, extra_classes = [])
    link_to "Remove",
            remove_path(edition.document),
            class: %w[link-danger] + Array(extra_classes)
  end

  def approve_button(edition, secondary: false)
    btn_class = secondary ? "btn-secondary" : "btn-primary"

    form_tag approve_path(edition.document),
             class: "mb-3" do
      submit_tag "Approve", class: %w[btn] + Array(btn_class)
    end
  end

  def create_preview_button(edition, secondary: false)
    btn_class = secondary ? "btn-secondary" : "btn-primary"

    form_tag preview_document_path(edition.document),
             class: "mb-3" do
      submit_tag "Preview", class: %w[btn] + Array(btn_class)
    end
  end

  def preview_link(edition, extra_classes = [])
    link_to "Preview",
            preview_document_path(edition.document),
            class: (extra_classes.present? ? Array(extra_classes) : nil)
  end
end
