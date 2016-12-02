delivery-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { parent.opts.title || 'Справочник доставок' }
        #{'yield'}(to="body")
            catalog(object='Delivery', cols='{ parent.cols }', remove='{ parent.remove }',
            reload='true', handlers='{ parent.handlers }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='code') { handlers.types[row.code].name }
                    datatable-cell(name='period') { row.period != 0 ? row.period + "дн." : ""  }
                    datatable-cell(name='price') { parseInt(row.price).toFixed(2) }
                    datatable-cell(name='note') { row.note }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'Delivery'
        self.handlers = {}

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'code', value: 'Тип'},
            {name: 'period', value: 'Период'},
            {name: 'price', value: 'Цена'},
            {name: 'note', value: 'Примечание'},
        ]

        self.on('mount', () => {
            API.request({
                object: 'DeliveryType',
                method: 'Fetch',
                success(response) {
                    self.handlers.types = {}
                    response.items.forEach(item => {
                        self.handlers.types[item.id] = {
                            code: item.code,
                            name: item.name
                        }
                    })
                },
                error(response) {
                    self.handlers.types = {}
                },
                complete() {
                    self.update()
                }
            })
        })