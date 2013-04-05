SimonAsks::Engine.routes.draw do

  get 'questions/tags/:tag', to: 'questions#index', as: :questions_tag
  resources :questions do
    get 'mark'
    get 'edit/image', to: 'questions#edit_image'
    get 'upvote'
    get 'downvote'
    resources :answers, controller: 'question_answers', only: [:create, :edit, :update, :destroy] do
      get 'upvote'
      get 'downvote'
      resources :comments, controller: 'answer_comments', only: [:create, :edit, :update, :destroy]
    end
    resources :comments, controller: 'question_comments', only: [:create, :edit, :update, :destroy]
  end
  resources :comments, only: %w(create update), constraints: { format: 'js' }

end
