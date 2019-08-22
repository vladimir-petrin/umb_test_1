module Api
  module V1
    class ApplicationController < ::ApplicationController
      private

      def render_errors(validation_result)
        render json: validation_result.errors.to_h, status: 422
      end
    end
  end
end
