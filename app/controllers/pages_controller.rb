require 'uri'
require 'net/http'
require 'openssl'
require 'date'

class PagesController < ApplicationController
  def home
    if params[:query].present?
      url = URI("https://tiktok-api6.p.rapidapi.com/search/general/query?query=#{params[:query]}")
    else
      url = URI("https://tiktok-api6.p.rapidapi.com/search/general/query?query=666armada")
    end

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = ENV['TIKTOK_KEY']
    request["X-RapidAPI-Host"] = ENV['TIKTOK_HOST']

    @response = http.request(request)
    @response = JSON.parse(@response.read_body)
    
    Video.destroy_all
    
    @response["videos"].each do |video|
      t = Time.at(video["create_time"])
      Video.create(
        duration: video["duration"],
        bitrate: video["bitrate"],
        create_time: t.to_datetime,
        author: video["author"]["nickname"],
        number_of_comments: video["statistics"]["number_of_comments"],
        number_of_hearts: video["statistics"]["number_of_hearts"],
        number_of_plays: video["statistics"]["number_of_plays"],
        number_of_reposts: video["statistics"]["number_of_reposts"],
        url: video["download_url"]
      )
    end
    @likes_by_month_and_author = Video.group_by_month(:create_time, format: "%B %Y").group(:author).sum(:number_of_hearts)
    @plays_by_month_and_author = Video.group_by_month(:create_time, format: "%B %Y").group(:author).sum(:number_of_plays)
    @reposts_by_month_and_author = Video.group_by_month(:create_time, format: "%B %Y").group(:author).sum(:number_of_reposts)
  end
end
