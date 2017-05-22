| import 'components/catalog.tag'
| import '../pko/pko-modal.tag'
| import './order-status-modal.tag'

orders-list

    catalog(object='Order', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
        add='{ permission(add, "orders", "0100") }',
        dblclick='{ permission(orderOpen, "orders", "1000") }',
        before-success='{ getAggregation }',store='orders-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='date', data-sign='>=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='date', data-sign='<=', format='DD.MM.YYYY')
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
            datatable-cell(name='serviceDate') { row.serviceDate }
            datatable-cell(name='serviceAddress') { row.address }
            datatable-cell(name='debt', style='background-color:{ red: row.debt > 0  } ')
                span { (row.debt / 1).toLocaleString() } ₽
            datatable-cell(name='amount')
                span { (row.amount / 1).toLocaleString() } ₽
            datatable-cell(name='status', style='background-color:{ handlers.statuses.colors[row.idStatus]  } ')
                | { handlers.statuses.text[row.idStatus]  }
            datatable-cell(name='note') { row.note }

        #{'yield'}(to='aggregation')
            strong Сумма заказов:
                span { (parent.totalAmount / 1 || 0).toLocaleString()  + " ₽  " }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')

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
            { name: 'serviceDate' , value: 'Дата доставки' },
            { name: 'serviceAddress' , value: 'Адрес доставки' },
            { name: 'debt' , value: 'Долг' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
            { name: 'note' , value: 'Примечание' },
        ]

        self.orderOpen = function (e) {
           // if (e.item.row.status != 'canceled' && e.item.row.status != 'completed')
                riot.route(`/orders/${e.item.row.id}`)
        }

        self.getAggregation = (response, xhr) => {
            self.totalAmount = response.totalAmount
        }


        self.getStatuses = () => {
            API.request({
                object: 'OrderStatus',
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



