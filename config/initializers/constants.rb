KLARSCHIFF_URL =
  case Rails.env
  when 'development'
    "http://#{ `hostname` }:3000"
  when 'consolidation'
    "http://klarschiff-test-#{ Settings::Client.key }"
  when 'production'
    "https://klarschiff-#{ Settings::Client.key }.de"
  else
  end
