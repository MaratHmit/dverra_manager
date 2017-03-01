| import 'components/catalog.tag'

measurements-list
    catalog(object='Measurement', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
        add='{ add }', remove='{ remove }', dblclick='{ edit }', store='requests-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='createdAt', data-sign='>=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='createdAt', data-sign='<=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label Статус замера
                        select.form-control(data-name='status')
                            option(value='') Все
                            option(value='0') Новые
                            option(value='1') В работе
                            option(value='2') Завершенные

        #{'yield'}(to="body")
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='customer') { row.customer }
            datatable-cell(name='customerPhone') { row.customerPhone }
            datatable-cell(name='serviceDate') { row.serviceDate }
            datatable-cell(name='serviceAddress') { row.serviceAddress }
            datatable-cell(name='serviceZone') { row.serviceZone }
            datatable-cell(name='note') { row.note }
            datatable-cell(name='status', class='{ handlers.statuses.colors[row.status]  } ')
                | { handlers.statuses.text[row.status]  }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Measurement'
        self.statuses = []
        self.statusesMap = { text: ['Новый', 'В работе', 'Завершен'], colors: ['bg-danger', 'bg-warning', 'bg-success'] }

        self.handlers = {
            statuses: self.statusesMap
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'date' , value: 'Дата заказа' },
            { name: 'customer' , value: 'Заказчик' },
            { name: 'customerPhone' , value: 'Телефон' },
            { name: 'serviceDate' , value: 'Дата замера' },
            { name: 'serviceAddress' , value: 'Адрес замера' },
            { name: 'serviceZone' , value: 'Район замера' },
            { name: 'note' , value: 'Заметка' },
            { name: 'status' , value: 'Статус' },
        ]

        self.edit = function (e) {
          riot.route(`/requests/measurements/${e.item.row.id}`)
        }

        self.add = () => riot.route(`/requests/measurements/new`)

        observable.on('measurements-reload', function () {
            self.tags.catalog.reload()
        })







