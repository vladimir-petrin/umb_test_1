module Api
  module V1
    class PostsController < ::Api::V1::ApplicationController
      def index
        validation_result = PostsIndexContract.new.call(params.permit!.to_h)

        return render_errors(validation_result) if validation_result.errors.present?

        posts = TopPostsQuery.call(validation_result.to_h)

        render json: posts, status: 200
      end

      def create
        validation_result = PostsCreateContract.new.call(params.permit!.to_h)

        return render_errors(validation_result) if validation_result.errors.present?

        post = CreatePostService.call(validation_result.to_h)

        render json: post.as_json(except: %i[author_ip]).merge('author_ip' => post.author_ip.to_s),
               status: 200
      end

      private

      def render_errors(validation_result)
        render json: validation_result.errors.to_h, status: 422
      end
    end
  end
end
