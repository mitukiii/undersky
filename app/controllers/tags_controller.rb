class TagsController < ApplicationController
  def recent
    name = URI.encode(params.delete(:name))
    response = client.tag_recent_media name, params
    @photos = response.data
    @pagination = response.pagination
    @tag = client.tag name
  end

end
