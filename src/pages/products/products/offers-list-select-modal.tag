offers-list-select-modal
    bs-modal(size='modal-lg')
        #{'yield'}(to="title")
            .h4.modal-title Торговые предложения
        #{'yield'}(to="body")
            .row
                .col-md-12
                    catalog-static(name="offersSelect", cols='{ parent.cols }', rows='{ parent.opts.offers }',
                        remove-toolbar='true', dblclick='{ parent.opts.submit.bind(this) }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='price') { (row.price / 1).toLocaleString() } ₽
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').

        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'}
        ]

