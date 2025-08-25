# frozen_string_literal: true

require "fhir_models"

# Decorator class for FHIR::Client that provides additional
# utility methods for working with parameter parts and extracting values.
class ClientDecorator < FHIR::Client
  def patch(path, patchset, headers)
    url = URI(build_url(path)).to_s
    FHIR.logger.info "PATCHING: #{url}"
    headers = clean_headers(headers)
    payload = request_patch_payload(patchset.to_json, headers['Content-Type'])
    if @use_oauth2_auth
      # @client.refresh!
      begin
        response = @client.patch(url, headers: headers, body: payload)
      rescue => e
        if !e.respond_to?(:response) || e.response.nil?
          # Re-raise the client error if there's no response. Otherwise, logging
          # and other things break below!
          FHIR.logger.error "PATCH - Request: #{url} failed! No response from server: #{e}"
          raise # Re-raise the same error we caught.
        end
        response = e.response if e.response
      end
      req = {
        method: :patch,
        url: url,
        path: url.gsub(@base_service_url, ''),
        headers: headers,
        payload: payload
      }
      res = {
        code: response.status.to_s,
        headers: response.headers,
        body: response.body
      }
      FHIR.logger.debug "PATCH - Request: #{req}, Response: #{response.body.force_encoding('UTF-8')}"
      @reply = FHIR::ClientReply.new(req, res, self)
    else
      headers.merge!(@security_headers) if @use_basic_auth
      begin
        @client.patch(url, payload, headers) do |resp, request, result|
          FHIR.logger.debug "PATCH - Request: #{request.to_json}, Response: #{resp.force_encoding('UTF-8')}"
          request.args[:path] = url.gsub(@base_service_url, '')
          res = {
            code: result.code,
            headers: scrubbed_response_headers(result.each_key {}),
            body: resp
          }
          @reply = FHIR::ClientReply.new(request.args, res, self)
        end
      rescue => e
        if !e.respond_to?(:response) || e.response.nil?
          # Re-raise the client error if there's no response. Otherwise, logging
          # and other things break below!
          FHIR.logger.error "PATCH - Request: #{url} failed! No response from server: #{e}"
          raise # Re-raise the same error we caught.
        end
        req = {
          method: :patch,
          url: url,
          path: url.gsub(@base_service_url, ''),
          headers: headers,
          payload: payload
        }
        res = {
          body: e.message
        }
        FHIR.logger.debug "PATCH - Request: #{req}, Response: #{response.body.force_encoding('UTF-8')}"
        FHIR.logger.error "PATCH Error: #{e.message}"
        @reply = FHIR::ClientReply.new(req, res, self)
      end
    end
  end
end