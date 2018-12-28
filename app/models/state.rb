require 'httparty'
require 'nokogiri'
require 'pry'
require "uri"
require 'resolv-replace'


class State < ApplicationRecord

  def self.get_dom_of_link(url)
    doc = HTTParty.get(url)
    dom = Nokogiri::HTML(doc)
  end

  def self.get_state_data
    main_url = "https://www.redfin.com/sitemap"
    sub_main_url = "https://www.redfin.com"
    state_dom = get_dom_of_link(main_url)
    state_list = state_dom.css("div.sitemap-section").css("div").css("ul.list").css("li").css("span").css("a")
    sold_filter = "/filter/include=sold-1mo"
    state_list.each do |state|
      state_link = state['href']
      new_state_link = state_link.sub("/newest-homes","")
      full_state_url = sub_main_url+new_state_link
      county_dom = get_dom_of_link(full_state_url)
      puts "Getting data from full state url -> #{full_state_url}"
      puts "--------------------------------------------------------"
      counties_list1 = county_dom.css("div.sitemap-section")
      counties_list = counties_list1[0].css("a")

      counties_list.each do |county|
        county_sub_link = county['href']
        state = county_sub_link.split("/").last
        puts "retrieving data from the state #{state}"
        puts "working with the  sublink -> #{county_sub_link}"
        county_link = "#{sub_main_url}#{county_sub_link}"
        puts "working with the county link #{county_link}"
        city_dom = get_dom_of_link(county_link)
        city_list1 = city_dom.css("div.sitemap-section")
        city_list = city_list1.css("span").css("a")

        city_list.each do |city|
          city_sub_url1 = city["href"].to_s
          city_split1 = city_sub_url1.split("/")
          city_split1[4] = ""
          city_split1[1] = "city"
          city_split = city_split1.reject { |e| e.to_s.empty? }
          city_sub_url = city_split.join("/")
          # puts city_sub_url
          city_url = sub_main_url+ "/" + city_sub_url + sold_filter
          puts city_url
          html_content = get_dom_of_link(city_url)
          if(html_content)
            total_pages = html_content.css('div .homes').text
            max_page_number = total_pages.split(/[^\d]/).last.to_i
            puts "Max houses sold #{max_page_number}"
            pagination = (max_page_number.to_f/20.to_f).ceil

            for page in 1..pagination
              inner_link = city_url + "/page-" + page.to_s
              puts "Inner link is #{inner_link}"
              inner_html_dom = get_dom_of_link(inner_link);
              city = inner_html_dom.css("div.sidepaneHeader").css("h1").text
              puts "working with data related to  the city -->> #{city} of state ---->>#{state}"

              if (inner_html_dom)
                page_min = (page - 1) * 20
                page_max = 20 * page
                puts "Min page no is #{page_min} and Max page no is #{page_max}"

                if page != pagination
                  for j in page_min...page_max
                    puts "Inner if loop j value is #{j}"

                    if (inner_html_dom.css("#MapHomeCard_#{j}"))
                      fetched_date = inner_html_dom.css("#MapHomeCard_#{j}").search("div.topleft").text
                      address = inner_html_dom.css("#MapHomeCard_#{j}").search("div.addressDisplay").text
                      price = inner_html_dom.css("#MapHomeCard_#{j}").search("span.homecardV2Price").text
                      home_details = inner_html_dom.css("#MapHomeCard_#{j}").search("div.HomeStatsV2").text
                      sold_date =Chronic.parse(fetched_date)
                      puts "House details price = #{price} // soldDate = #{sold_date} // address = #{address} // house-details = #{home_details} // city = #{city} state = #{state}"
                      State.find_or_create_by(date: sold_date, address: address, price: price, home_details: home_details, state_name:state, city:city)
                    end
                  end
                elsif page == pagination
                  start = (page - 1) * 20
                  x = max_page_number % 20 + start

                  for j in start...x
                    puts "Inner else if loop j value is #{j}"

                    if (inner_html_dom.css("#MapHomeCard_#{j}"))
                      fetched_date = inner_html_dom.css("#MapHomeCard_#{j}").search("div.topleft").text
                      address = inner_html_dom.css("#MapHomeCard_#{j}").search("div.addressDisplay").text
                      price = inner_html_dom.css("#MapHomeCard_#{j}").search("span.homecardV2Price").text
                      home_details = inner_html_dom.css("#MapHomeCard_#{j}").search("div.HomeStatsV2").text
                      sold_date =Chronic.parse(fetched_date)
                      puts "House details price = #{price} // soldDate = #{sold_date} // address = #{address} // house-details = #{home_details} // city = #{city} state = #{state}"
                      State.find_or_create_by(date: sold_date, address: address, price: price, details: home_details, state_name:state, city:city)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

