

get '/modification/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_modifications = Modification.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :modification_all
end