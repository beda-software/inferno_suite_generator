begin
  require 'fhir_client'
rescue LoadError
end

module FHIR
  class Client
    def request_patch_payload(patchset, format)
      puts "HELLO WORLD"
      puts "patchset: #{patchset}"
      if patchset && patchset.respond_to?(:resourceType) && patchset.resourceType == 'Parameters'
        fmt = format.to_s.downcase
        if fmt.include?('json')
          return patchset.to_json
        elsif fmt.include?('xml')
          return patchset.to_xml
        else
          default_fmt = (defined?(@default_format) && @default_format) ? @default_format.to_s.downcase : ''
          return default_fmt.include?('xml') ? patchset.to_xml : patchset.to_json
        end
      end

      if format == FHIR::Formats::PatchFormat::PATCH_JSON
        patchset.each do |patch|
          patch[:path] = patch[:path].slice(patch[:path].index('/')..-1)
        end
        return patchset.to_json
      end

      if format == FHIR::Formats::PatchFormat::PATCH_XML
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          patchset.each do |patch|
            xml.diff do
              # TODO: support other kinds besides just replace
              xml.replace(patch[:value], sel: patch[:path] + '/@value') if patch[:op] == 'replace'
            end
          end
        end
        return builder.to_xml
      end

      fmt = format.to_s.downcase
      if patchset.respond_to?(:to_json) && fmt.include?('json')
        patchset.to_json
      elsif patchset.respond_to?(:to_xml) && fmt.include?('xml')
        patchset.to_xml
      else
        patchset
      end
    end
    private :request_patch_payload
  end
end
