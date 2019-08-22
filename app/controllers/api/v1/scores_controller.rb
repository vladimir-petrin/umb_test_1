module Api
  module V1
    class ScoresController < ::Api::V1::ApplicationController
      def create
        post = find_post

        validation_result = ScoresCreateContract.new.call(params.permit!.to_h)

        return render_errors(validation_result) if validation_result.errors.present?

        CreateScoreService.call(post, validation_result.to_h)

        render json: { avg_score: post.reload.avg_score }, status: 200
      end

      private

      def find_post
        Post.find(params[:post_id])
      end
    end
  end
end
