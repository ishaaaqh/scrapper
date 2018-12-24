
require 'httparty'
require 'nokogiri'
require 'pry'
require 'chronic'

class Scraper < ApplicationRecord
  def self.get_scraped_data
    links = [
      'https://www.redfin.com/county/531/GA/Cherokee-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/510/GA/Barrow-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/511/GA/Bartow-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/521/GA/Butts-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/525/GA/Carroll-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/534/GA/Clayton-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/536/GA/Cobb-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/536/GA/Coweta-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/559/GA/Fayette-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/545/GA/Dawson-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/547/GA/DeKalb-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/551/GA/Douglas-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/561/GA/Forsyth-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/563/GA/Fulton-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/570/GA/Gwinnett-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/572/GA/Hall-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/574/GA/Haralson-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/577/GA/Heard-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/578/GA/Henry-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/582/GA/Jasper-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/588/GA/Lamar-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/602/GA/Meriwether-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/610/GA/Newton-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/613/GA/Paulding-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/615/GA/Pickens-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/617/GA/Pike-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/625/GA/Rockdale-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/629/GA/Spalding-County/filter/include=sold-1wk',
      'https://www.redfin.com/county/650/GA/Walton-County/filter/include=sold-1wk',
    ]

    links.each do |url|
      puts "Parent url is #{url}"

      html_content = get_dom_of_link(url)

      if (html_content)
        total_pages = html_content.css('div .homes').text

        max_page_number = total_pages.split(/[^\d]/).max.to_i

        pagination = (max_page_number.to_f/20.to_f).ceil

        for page in 1..pagination
          inner_link = url + "/page-" + page.to_s
          inner_html_dom = get_dom_of_link(inner_link);

          if (inner_html_dom)
            page_min = (page - 1) * 20
            page_max = 20 * page

            if page != pagination
              for j in page_min...page_max

                if (inner_html_dom.css("#MapHomeCard_#{j}"))
                  data = inner_html_dom.css("#MapHomeCard_#{j}").css(".HomeCard").text
                  fetched_date = inner_html_dom.css("#MapHomeCard_#{j}").search("div.topleft").text
                  address = inner_html_dom.css("#MapHomeCard_#{j}").search("div.addressDisplay").text
                  price = inner_html_dom.css("#MapHomeCard_#{j}").search("span.homecardV2Price").text
                  home_details = inner_html_dom.css("#MapHomeCard_#{j}").search("div.HomeStatsV2").text
                  sold_date = Chronic.parse(fetched_date)
                  puts "House details price = #{price} // soldDate = #{sold_date} // address = #{address} // house-details = #{home_details} //"

                  Scraper.find_or_create_by(date: sold_date, address: address, price: price, home_details: home_details)
                end
              end
            elsif page == pagination
              start = (page - 1) * 20
              x = max_page_number % 20 + start

              for j in start...x
                puts "Inner else if loop j value is #{j}"

                if (inner_html_dom.css("#MapHomeCard_#{j}"))
                  data = inner_html_dom.css("#MapHomeCard_#{j}").css(".HomeCard").text
                  fetched_date = inner_html_dom.css("#MapHomeCard_#{j}").search("div.topleft").text
                  address = inner_html_dom.css("#MapHomeCard_#{j}").search("div.addressDisplay").text
                  price = inner_html_dom.css("#MapHomeCard_#{j}").search("span.homecardV2Price").text
                  home_details = inner_html_dom.css("#MapHomeCard_#{j}").search("div.HomeStatsV2").text
                  sold_date = Chronic.parse(fetched_date)
                  puts "House details price = #{price} // soldDate = #{sold_date} // address = #{address} // house-details = #{home_details} //"

                  Scraper.find_or_create_by(date: sold_date, address: address, price: price, home_details: home_details)
                end
              end
            end
          end
        end
      end
    end
  end

  def self.get_dom_of_link(url)
    doc = HTTParty.get(url)
    Nokogiri::HTML(doc)
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names

      all.each do |result|
        csv << result.attributes.values_at(*column_names)
      end
    end
  end
end
