require 'httparty'
require 'nokogiri'
require 'pry'
require 'resolv-replace'

class City < ApplicationRecord

def self.get_dom_of_link(url)
  doc = HTTParty.get(url)
  dom = Nokogiri::HTML(doc)
end

def self.get_city_data
      link = "https://www.redfin.com/"
      puts link
      main_page_content = get_dom_of_link(link)
      puts main_page_content
      puts "completed"
      puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=="
      city_list = main_page_content.css("div.Eigencities").css("a")
      puts city_list[0]
      city_list.each do |estate|
        city_link = estate['href']
        full_link = "https://www.redfin.com/#{city_link}/filter/include=sold-1mo"
        puts full_link
        html_content =get_dom_of_link(full_link)

          if (html_content)
              total_pages = html_content.css('div .homes').text
              max_page_number = total_pages.split(/[^\d]/).max.to_i
              puts "Max pages number #{max_page_number}"
              pagination = (max_page_number.to_f/20.to_f).ceil

            for page in 1..pagination
              inner_link =  full_link + "/page-" + page.to_s
              puts "Inner link is #{inner_link}"
              inner_html_dom = get_dom_of_link(inner_link);

            if (inner_html_dom)
              page_min = (page - 1) * 20
              page_max = 20 * page
              puts "Min page no is #{page_min} and Max page no is #{page_max}"

            if page != pagination
              for j in page_min...page_max
                puts "Inner if loop j value is #{j}"

                    if(inner_html_dom.css("#MapHomeCard_#{j}"))
                      data = inner_html_dom.css("#MapHomeCard_#{j}").css(".HomeCard").text
                      fetched_date = inner_html_dom.css("#MapHomeCard_#{j}").search("div.topleft").text
                      address = inner_html_dom.css("#MapHomeCard_#{j}").search("div.addressDisplay").text
                      price = inner_html_dom.css("#MapHomeCard_#{j}").search("span.homecardV2Price").text
                      home_details = inner_html_dom.css("#MapHomeCard_#{j}").search("div.HomeStatsV2").text
                      sold_date = Chronic.parse(fetched_date)
                      puts "House details price = #{price} // soldDate = #{sold_date} // address = #{address} // house-details = #{home_details} //"
                      City.find_or_create_by(date: sold_date, address: address, price: price, home_details: home_details, city:city)
                    end
              end
            elsif page == pagination
              start = (page - 1) * 20
              x = max_page_number % 20 + start

              for j in start...x
                puts "Inner else if loop j value is #{j}"

                if(inner_html_dom.css("#MapHomeCard_#{j}"))
                  data = inner_html_dom.css("#MapHomeCard_#{j}").css(".HomeCard").text
                  fetched_date = inner_html_dom.css("#MapHomeCard_#{j}").search("div.topleft").text
                  address = inner_html_dom.css("#MapHomeCard_#{j}").search("div.addressDisplay").text
                  price = inner_html_dom.css("#MapHomeCard_#{j}").search("span.homecardV2Price").text
                  home_details = inner_html_dom.css("#MapHomeCard_#{j}").search("div.HomeStatsV2").text
                  sold_date = Chronic.parse(fetched_date)
                  puts "House details price = #{price} // soldDate = #{sold_date} // address = #{address} // house-details = #{home_details} //"
                  City.find_or_create_by(date: sold_date, address: address, price: price, home_details: home_details, city:city)
                end
              end
            end
          end
        end
      end
    end
  end
end







