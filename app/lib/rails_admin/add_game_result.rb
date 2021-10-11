require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class AddGameResult < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
        register_instance_option :visible? do
          authorized? && bindings[:object].started? && !bindings[:object].finished?
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-plus'
        end

        register_instance_option :http_methods do
          %i[get post]
        end

        register_instance_option :controller do
          proc do
            @matchup = @object
            if @matchup.finished? || !@matchup.started?
              redirect_to show_path(model_name: @abstract_model.model_name, id: @object.id)
            elsif request.post?
              @matchup.update!(params.require(:matchup).permit(:favorite_wins, :underdog_wins))
              redirect_to show_path(model_name: @abstract_model.model_name, id: @object.id)
            end
          end
        end
      end
    end
  end
end
