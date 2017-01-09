shop-services-list-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Услуги
        #{'yield'}(to="body")
            catalog(object='ShopService', cols='{ parent.cols }', search='true', reload='true', sortable='true')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='price') { row.price }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
        ]

