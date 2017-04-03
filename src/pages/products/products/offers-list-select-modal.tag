offers-list-select-modal
    bs-modal(size='modal-lg')
        #{'yield'}(to="title")
            .h4.modal-title Товары
        #{'yield'}(to="body")
            .row
                    catalog(object='Product', disable-col-select='true', cols='{ parent.cols }',
                    filters='{ parent.categoryFilters }', search='true', reload='true', sortable='true',
                    dblclick='{ parent.opts.submit.bind(this) }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='price') { (row.price / 1).toFixed(2) }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').