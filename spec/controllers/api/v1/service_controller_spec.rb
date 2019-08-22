require 'rails_helper'

RSpec.describe Api::V1::ServiceController, type: :request do
  describe '#posters' do
    let!(:users) do
      [
        create(:user, login: 'vasya'),
        create(:user, login: 'nikolay')
      ]
    end

    let!(:posts) do
      [
        create(:post, user: users[0], author_ip: IPAddr.new('127.0.0.1')),
        create(:post, user: users[1], author_ip: IPAddr.new('127.0.0.1')),
        create(:post, user: users[0], author_ip: IPAddr.new('192.168.1.1')),
      ]
    end

    context 'when requested users exist' do
      before do
        get api_v1_service_posters_path, params: { logins: ['vasya', 'nikolay'] }
      end

      it 'returns response with 200 status' do
        expect(response).to have_http_status(200)
      end

      it 'returns ip addresses with array of users posted from it' do
        json = JSON.parse(response.body)
        expect(json).to match_array(
          [
            ['127.0.0.1', ['vasya', 'nikolay']],
            ['192.168.1.1', ['vasya']]
          ]
        )
      end
    end

    context 'when at least one requested user do not exist' do
      before do
        get api_v1_service_posters_path, params: { logins: ['vasya', 'nikolay', 'alisa'] }
      end

      it 'returns response with 200 status' do
        expect(response).to have_http_status(422)
      end

      it 'returns errors' do
        json = JSON.parse(response.body)
        expect(json).to eq("logins"=>["users with logins: [\"alisa\"] not found"])
      end
    end
  end
end