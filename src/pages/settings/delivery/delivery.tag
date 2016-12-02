delivery
    catalog(object='Delivery', cols='{ cols }', reload='true', handlers='{ handlers }',
    add='{ permission(add, "deliveries", "0100") }',
    remove='{ permission(remove, "deliveries", "0001") }',
    dblclick='{ permission(deliveryOpen, "deliveries", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='code') { handlers.types[row.code].name }
            datatable-cell(name='period') { row.period != 0 ? row.period + "дн." : ""  }
            datatable-cell(name='price') { parseInt(row.price).toFixed(2) }
            datatable-cell(name='note') { row.note }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
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

        self.add = () => riot.route('/settings/delivery/new')

        self.deliveryOpen = e => riot.route(`settings/delivery/${e.item.row.id}`)

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

        observable.on('delivery-reload', () => {
            self.tags.catalog.reload()
        })
