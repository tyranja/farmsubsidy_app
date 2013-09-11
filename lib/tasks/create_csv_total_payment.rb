require 'csv'
require 'rubygems'
require 'sequel'
require 'logger'


# connect to an postgres database
DB = Sequel.postgres("farmsubsidy_performance", :loggers => [Logger.new($stdout)])

# connects to the models

# __FILE__ is a reference to the current file name
# absolute_path converts a pathname to an absolute pathname
# File.dirname gets the directory
tasks_dir = File.dirname(File.absolute_path(__FILE__))
# substitudes "lib" and "tasks" to get to the project directory
project_root = tasks_dir.gsub(/lib\/tasks/,"")
Dir.glob(project_root + "/models/*.rb").each{|f| require f}

payments_sorted = Payment.sorted(2007,200)

top_payments = []

# find recipient name, create an index, shove it into top_payments hash
payments_sorted.each_with_index do |payment, index|
  recipient_name = Recipient.where(id: payment[:recipient_id]).first[:name].gsub("\"", "")
  top_payments << {rank: index+1, name: recipient_name, amount: payment[:amount_euro]}
end

CSV.open("#{project_root}/csv/top_payments.csv", "w", :force_quotes => true) do |csv|
  i = 0
  csv << ["rank","name","amount"]
  while i < top_payments.length
    csv << [top_payments[i][:rank],top_payments[i][:name],top_payments[i][:amount].to_i]
    i += 1
  end
end

puts "our results are: "
system("cat #{project_root}/csv/top_payments.csv")
