require 'base64'
require 'json'

module Playwright
  define_api_implementation :APIRequestImpl do
    def initialize(playwright)
      @playwright = playwright
    end

    def new_context(
          baseURL: nil,
          clientCertificates: nil,
          extraHTTPHeaders: nil,
          failOnStatusCode: nil,
          httpCredentials: nil,
          ignoreHTTPSErrors: nil,
          maxRedirects: nil,
          proxy: nil,
          storageState: nil,
          timeout: nil,
          userAgent: nil)
      params = {
        baseURL: baseURL,
        clientCertificates: prepare_client_certificates(clientCertificates),
        extraHTTPHeaders: extraHTTPHeaders ? HttpHeaders.new(extraHTTPHeaders).as_serialized : nil,
        failOnStatusCode: failOnStatusCode,
        httpCredentials: httpCredentials,
        ignoreHTTPSErrors: ignoreHTTPSErrors,
        maxRedirects: maxRedirects,
        proxy: proxy,
        storageState: prepare_storage_state(storageState),
        timeout: timeout,
        userAgent: userAgent,
      }.compact

      result = @playwright.channel.send_message_to_server_result('newRequest', params)
      context = ChannelOwners::APIRequestContext.from(result['request'])
      context.send(:_update_timeout_settings, TimeoutSettings.new.tap { |settings| settings.default_timeout = timeout if timeout })
      context
    end

    private def prepare_storage_state(storage_state)
      storage_state.is_a?(String) ? JSON.parse(File.read(storage_state)) : storage_state
    end

    private def prepare_client_certificates(client_certificates)
      return unless client_certificates.is_a?(Array)

      client_certificates.filter_map do |item|
        out_record = {
          origin: item[:origin],
          passphrase: item[:passphrase],
        }

        { pfxPath: 'pfx', certPath: 'cert', keyPath: 'key' }.each do |key, out_key|
          if (filepath = item[key])
            out_record[out_key] = Base64.encode64(File.read(filepath)) rescue ''
          elsif (value = item[out_key.to_sym])
            out_record[out_key] = value
          end
        end

        out_record.compact!
        next nil if out_record.empty?

        out_record
      end
    end
  end
end
