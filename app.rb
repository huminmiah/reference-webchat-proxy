require 'sinatra'
require 'httparty'
require 'pry'
require 'json'

EGAIN_NORMALISATION = {
  "0" => "AVAILABLE",
  "1" => "UNAVAILABLE",
  "2" => "BUSY"
}

def failure_response
  {
    status: "failure",
    response: "unknown"
  }.to_json
end

get '/availability/:id' do
  # SET CORS HEADERS SO IT CAN BE ACCESSED VIA JS
  headers \
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Methods" => "GET",
    "Access-Control-Allow-Headers" =>  "Content-Type",
    "Access-Control-Max-Age" => "86400"

  response          = HTTParty.get("https://online.hmrc.gov.uk/webchatprod/egain/chat/entrypoint/checkEligibility/" + params[:id])
  egain_status      = response.parsed_response["checkEligibility"]["responseType"]
  normalised_status = EGAIN_NORMALISATION[egain_status]

  content_type :json

  if normalised_status.nil?
    status 500
    return failure_response
  end

  {
    status: "success",
    response: normalised_status
  }.to_json
end

get '/open/:id' do
  redirect to("https://online.hmrc.gov.uk/webchatprod/templates/chat/hmrc7/chat.html?entryPointId=#{params[:id]}&templateName=hmrc7&languageCode=en&countryCode=US&ver=v11")
end

# ALLOW OPTIONS REQUEST THROUGH CORS
# https://github.com/britg/sinatra-cross_origin#responding-to-options
options "*" do
  response.headers["Allow"] = "HEAD,GET,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end
