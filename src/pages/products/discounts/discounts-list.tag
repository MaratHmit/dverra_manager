discounts-list
    catalog(object='Discount', cols='{ cols }', reload='true', handlers='{ handlers }', store='discounts-list', reorder='true',
    add='{ permission(add, "products", "0100") }',
    remove='{ permission(remove, "products", "0001") }',
    dblclick='{ permission(open, "products", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='dateFrom') { row.dateFrom }
            datatable-cell(name='dateTo') { row.dateTo }
            datatable-cell(name='stepTime') { row.stepTime }ч.
            datatable-cell(name='stepDiscount') { row.stepDiscount }
            datatable-cell(name='sumFrom') { row.sumFrom }
            datatable-cell(name='sumTo') { row.sumTo }
            datatable-cell(name='countFrom') { row.countFrom }
            datatable-cell(name='countTo') { row.countTo }
            datatable-cell(name='week') { handlers.getListOfDays(row.week) }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Discount'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'dateFrom', value: 'Старт'},
            {name: 'dateTo', value: 'Завершение'},
            {name: 'stepTime', value: 'Шаг времени'},
            {name: 'stepDiscount', value: 'Шаг скидки'},
            {name: 'sumFrom', value: 'От суммы'},
            {name: 'sumTo', value: 'До суммы'},
            {name: 'countFrom', value: 'От кол-ва'},
            {name: 'countTo', value: 'До кол-ва'},
            {name: 'week', value: 'Дни недели'},
        ]

        self.handlers = {
            daysOfWeek: ['Пн.', 'Вт.', 'Ср.', 'Чт.', 'Пт.', 'Сб.', 'Вс.'],
            getListOfDays(days) {
                let items = days.split('')

                let result = items
                    .map((item, i) => (item == 1 ? this.daysOfWeek[i] : undefined))
                    .filter(item => item)
                    .join(',')

                return result
            }
        }

        observable.on('discount-reload', () => self.tags.catalog.reload())

        self.add= () => {
            riot.route(`products/discounts/new`)
        }

        self.open = e => {
            riot.route(`products/discounts/${e.item.row.id}`)
        }