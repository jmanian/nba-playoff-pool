RailsAdmin.config do |config|
  ## == Naming ==
  config.main_app_name = "Sports Pals"

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      only %w[Matchup Pick]
    end
    export
    bulk_delete
    show
    edit do
      only %w[User Matchup Pick]
    end
    delete do
      only %w[Matchup]
    end
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model "User" do
    list do
      field :id
      field :email
      field :username
      field :admin
    end
    edit do
      field :email
      field :username
      field :password
      field :admin
    end
  end

  config.model "Matchup" do
    list do
      field :id
      field :sport
      field :year
      field :title
    end
    edit do
      exclude_fields :picks
    end
  end

  config.model "Pick" do
    list do
      exclude_fields :created_at, :updated_at
    end
    edit do
      field :user do
        read_only do
          bindings[:object].persisted?
        end
      end
      field :matchup do
        read_only do
          bindings[:object].persisted?
        end
      end
      field :winner_is_favorite do
        read_only do
          bindings[:object].persisted?
        end
      end
      field :num_games do
        read_only do
          bindings[:object].persisted?
        end
      end
      field :penalty
    end
  end
end
