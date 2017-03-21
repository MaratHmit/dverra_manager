discounts-list-modal-select
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Скидки
        #{'yield'}(to="body")
            catalog(object='Discount', cols='{ parent.cols }', reload='true', handlers='{ parent.handlers }')
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
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

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