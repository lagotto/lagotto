
class Biod < Source

  SOURCE_URL = 'http://www.plosreports.org/services/rest?method=usage.stats&journal=biod&doi='

  def get_data(article, options={})

    query_url = "#{SOURCE_URL}#{CGI.escape(article.doi)}"

    get_xml(query_url, options) do |document|
      views = []
      event_count = 0
      document.find("//rest/response/results/item").each do | view |

        month = view.find_first("month")
        year = view.find_first("year")
        month = view.find_first("month")
        html = view.find_first("get-document")
        xml = view.find_first("get-xml")
        pdf = view.find_first("get-pdf")

        curMonth = {}
        curMonth[:month] = month.content
        curMonth[:year] = year.content

        if pdf
          curMonth[:pdf_views] = pdf.content
          event_count += pdf.content.to_i
        else
          curMonth[:pdf_views] = 0
        end

        if xml
          curMonth[:xml_views] = xml.content
          event_count += xml.content.to_i
        else
          curMonth[:xml_views] = 0
        end

        if html
          curMonth[:html_views] = html.content
          event_count += html.content.to_i
        else
          curMonth[:html_views] = 0
        end

        views << curMonth
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => views,
       :events_url => query_url,
       :event_count => event_count,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }
    end

  end

end