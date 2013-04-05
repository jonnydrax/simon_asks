require 'validators/simon_asks/file_size_validator'

module SimonAsks
  class Question < ActiveRecord::Base

    include PgSearch

    ITEMS_PER_PAGE = 10

    pg_search_scope :search_by_title_and_content, against: [:title, :content], using: { tsearch: { prefix: true} }

    belongs_to :user, :class_name => SimonAsks.user_class
    has_many :answers, class_name: 'QuestionAnswer', dependent: :destroy
    has_many :comments, as: 'owner', dependent: :destroy

    mount_uploader :image, QuestionUploader
    acts_as_taggable
    acts_as_votable

    attr_accessible :title, :content, :user, :tag_list, :image, :image_cache,
      :remove_image

    after_destroy :clear_files

    validates :image, file_size: { maximum: 2.megabytes.to_i },
      if: lambda { |o| o.image_cache.blank? }
    validates_presence_of :title, :content, :user, :tag_list

    default_scope includes([answers: :comments], :comments, :user).order('created_at DESC')

    auto_html_for :content do
      html_escape
      image
      youtube(:width => 400, :height => 250)
      link :target => "_blank", :rel => "nofollow"
      simple_format
    end

    def self.cached_latest
      Rails.cache.fetch("latest_questions", :expires_in => 10.minutes) {
        where(marked: false).limit(6)
      }
    end

    def self.cached_most_read
      Rails.cache.fetch("most_read_questions", :expires_in => 10.minutes) {
        unscoped.order("views_count DESC").limit(3).all
      }
    end

    def self.related_to(question)
      where('questions.id != ?', question.id)
      .tagged_with(question.tag_list, :any => true)
      .limit(20)
    end

    def self.search(params)
      params = {query: ''} if params.nil?
      search_by_title_and_content(params[:query])
    end

    # incements views_counter by one
    def increment_views!
      increment!('views_count')
    end

    # Mark question as a question of the day
    def mark!
      self.marked = true
      save!
    end

    # Unmark question as a question of the day
    def unmark!
      self.marked = false
      save!
    end

    # upvotes minus downvotes
    def score
      upvotes.size - downvotes.size
    end

    # true if user answered the question
    def has_answer_by?(user)
      true if answers.find_all_by_user_id(user.id).any?
    end

    private

    def clear_files
      FileUtils.rm_rf(File.dirname(self.image.current_path)) unless image.current_path.nil?
    end
  end
end