class Requirements::Form::FileAttachmentMetadataChecker
  include Requirements::Checker

  UNIQUE_REF_MAX_LENGTH = 255
  ISBN10_REGEX = /^(?:\d[\ -]?){9}[\dX]$/i
  ISBN13_REGEX = /^(?:\d[\ -]?){13}$/i

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def check
    unless valid_isbn?(params[:isbn])
      issues.create(:file_attachment_isbn, :invalid)
    end

    if params[:unique_reference].to_s.size > UNIQUE_REF_MAX_LENGTH
      issues.create(:file_attachment_unique_reference,
                    :too_long,
                    max_length: UNIQUE_REF_MAX_LENGTH)
    end
  end

private

  def valid_isbn?(isbn)
    isbn.blank? || ISBN10_REGEX.match?(isbn) || ISBN13_REGEX.match?(isbn)
  end
end
