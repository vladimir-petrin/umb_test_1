module Api
  module V1
    class ServiceController < ::Api::V1::ApplicationController
      def posters
        validation_result = ServicePostersContract.new.call(params.permit!.to_h)

        return render_errors(validation_result) if validation_result.errors.present?

        posters_info = PostersQuery.call(validation_result.to_h)

        render json: posters_info, status: 200
      end
    end
  end
end
