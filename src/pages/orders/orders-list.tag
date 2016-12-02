| import 'components/catalog.tag'

orders-list

    catalog(object='Order', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
    add='{ permission(add, "orders", "0100") }',
    remove='{ permission(remove, "orders", "0001") }',
    dblclick='{ permission(orderOpen, "orders", "1000") }',
    before-success='{ getAggregation }',store='orders-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='date', data-sign='>=', format='YYYY-MM-DD')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='date', data-sign='<=', format='YYYY-MM-DD')
                    .form-group
                        label.control-label Статус заказа
                        select.form-control(data-name='idStatus')
                            option(value='') Все
                            option(each='{ parent.statuses }', value='{ id }', no-reorder) { name }

        #{'yield'}(to="body")
            datatable-cell(name='num') { row.num }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='customer') { row.customer }
            datatable-cell(name='customerPhone') { row.customerPhone }
            datatable-cell(name='amount') { row.amount }
            datatable-cell(name='status', style='background-color:{ handlers.statuses.colors[row.idStatus]  } ')
                | { handlers.statuses.text[row.idStatus]  }

        #{'yield'}(to='aggregation')
            strong Сумма заказов: { (parent.totalAmount || 0) +  " " }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Order'
        self.statuses = []
        self.statusesMap = { text: {}, colors: {} }

        self.handlers = {
            statuses: self.statusesMap
        }
        self.cols = [
            { name: 'num' , value: '№' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'customer' , value: 'Заказчик' },
            { name: 'customerPhone' , value: 'Телефон' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
        ]

        self.orderOpen = function (e) {
            riot.route(`/orders/${e.item.row.id}`)
        }

        self.getAggregation = (response, xhr) => {
            self.totalAmount = response.totalAmount
        }

        self.add = () => riot.route('/orders/new')

        self.getStatuses = () => {
            let data = { sortBy: "id", sortOrder: "asc", limit: 1000 }
            API.request({
                object: 'OrderStatus',
                data: data,
                method: 'Fetch',
                success(response) {
                    self.statuses = response.items
                    self.statuses.forEach(function(item) {
                        self.statusesMap.text[item.id] = item.name
                        self.statusesMap.colors[item.id] = "#" + item.color
                    })
                    self.update()
                }
            })
        }

        observable.on('orders-reload', function () {
            self.tags.catalog.reload()
        })

        self.getStatuses()



