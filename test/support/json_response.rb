# frozen_string_literal: true

module JsonResponse

  def json
    @json ||= JSON.parse(response.body)
  end

  def json_attrs(attr)
    json['data'].collect { |s| s['attributes'][attr.to_s] }
  end

end
