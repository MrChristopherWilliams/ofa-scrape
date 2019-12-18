# Scrape of OFA database
require 'watir'
require 'webdrivers'
require 'open-uri'
require 'nokogiri'
require 'csv'

# Open Oxbridge Founders
browser = Watir::Browser.new
browser.goto 'secret'

# Enter login details and click login
browser.text_field(id: 'email').set 'secret'
browser.text_field(id: 'pwd').set 'secret'
browser.button(type: 'submit').click

# Scrape data
browser.wait_until { browser.h1.text != 'Welcome to secret' }
page = Nokogiri::HTML.parse(browser.html)

data_rows = page.css('tr')
data = []
data_rows.each do |data_row|
  data2 = []
  data_row.css('td').each do |cell|
    data2 << cell.text
    email = cell.at_css('a:contains("Email")')
    if email.nil?
    else
      email = email.to_s
      email = email.scan(/\btitle="[\w+\-.]+@[a-z\d\-.]+\.[a-z]+"/)[0]
      if email.nil?
      else
      email = email.gsub(/title="/, '').gsub(/"/, '')
      end
    end
    data2 << email
    linkedin = cell.at_css('a:contains("LinkedIn")')
    if linkedin.nil?
    else
      linkedin = linkedin.to_s
      linkedin = linkedin.scan(/\linkedin.com\/\S*/)[0]
      if linkedin.nil?
      else
      linkedin = linkedin.gsub(/"/, '')
      end
    end
    data2 << linkedin
  end
  data << data2
end

# Remove unneccessary characters from bio
data.each_with_index do |x, i|
  if i.even?
    if x[0].nil?
    else
      save = x[0].gsub(/\n/, '').gsub(/\n/, '')
      data[i] = save.strip
    end
    data[i]
  end
end

# Remove blank columns and white space
data.each_with_index do |_, i|
  set = [1, 2, 3, 7, 8, 10, 11, 13, 14, 16, 17, 19, 20, 22, 23, 25, 26, 27, 28, 29, 30]
  if i.odd?
    data[i].delete_if.with_index { |_, index| set.include? index }
    data[i][6] = data[i][6].strip
  end
end

# Add elements at even indexes to odd
data.each_with_index do |_, i|
  if i.odd?
    data[i] << data[i + 1]
  end
end

# Export to csv
headers = ["Name", "Email", "LinkedIn", "Current Profile", "Current Industry", "Country", "University", "College", "Graduation Year", "City", "Bio"]
csv_options = { col_sep: ',' }
CSV.open('../scrape.csv', 'wb', csv_options) do |csv|
  csv << headers
  data.each_with_index do |_, i|
    if i.odd?
      csv << data[i]
    end
  end
end
