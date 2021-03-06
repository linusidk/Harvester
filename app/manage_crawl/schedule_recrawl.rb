require 'pry'

module ScheduleRecrawl
  include CollectData
  include RecrawlTime
  # Save recrawl_frequency, recrawl_interval, next_recrawl_time
  def save_rescrape_info(collection, selector_list, recrawl_frequency, recrawl_interval)
    # Save frequency and interval for dataset
    collection.update_attributes({recrawl_frequency: recrawl_frequency, recrawl_interval: recrawl_interval})
    collection.save

    # Get next rescrape time
    next_recrawl_time = calculate_next_rescrape(recrawl_frequency, recrawl_interval) 
    
    # Loop through items and set recrawl frequency, interval, and next rescrape time
    selector_list.each do |r|
      r.update_attributes({recrawl_frequency: recrawl_frequency,
                           recrawl_interval: recrawl_interval,
                           next_recrawl_time: next_recrawl_time
                          })
      r.save
    end
  end

  # Check if the recrawl schedule changed and update it on selector list if so
  def check_if_schedule_changed(collection, selector_list, recrawl_frequency, recrawl_interval)
    if (collection.recrawl_frequency != recrawl_frequency) || (collection.recrawl_interval != recrawl_interval)
      save_rescrape_info(collection, selector_list, recrawl_frequency, recrawl_interval)
    end
  end

  # Check which terms need to be recrawled
  def check_recrawl
    need_recrawl = Term.all.select{|t| Time.now >= t.next_recrawl_time if t.next_recrawl_time}

    # Recrawl each term
    need_recrawl.each do |t|
      Resque.enqueue(CollectData, t.dataset.source, t.dataset, [t])
    end
  end
end
