
schedule-events
    .well.well-sm(if='{ !opts.modal }')
        .form-inline
            .form-group
                label.control-label От даты
                datetime-picker.form-control(data-name='startDate', data-sign='>=', format='DD.MM.YYYY', value='{ startDate }')
            .form-group
                label.control-label До даты
                datetime-picker.form-control(data-name='endDate', data-sign='<=', format='DD.MM.YYYY', value='{ endDate }')
    .row
        .col-md-8.col-sm-6.col-xs-12
            .form-inline.m-b-2
                button.btn.btn-success(onclick='{ reload }', title='Обновить', type='button')
                    i.fa.fa-refresh
                .dropdown(if='{ isSelected }', style='display: inline-block;')
                    button.btn.btn-default.dropdown-toggle(data-toggle="dropdown", aria-haspopup="true", type='button', aria-expanded="true")
                        | Действия&nbsp;
                        span.caret
                    ul.dropdown-menu
                        li(onclick='{ handlers.block }')
                            a(href='#')
                                |  Запретить для выбора
                        li(onclick='{ handlers.unBlock }')
                            a(href='#')
                                |  Разрешить для выбора
    .table-responsive
        table.table.table-bordered
            thead
                tr
                    th Время
                    th Заказ/замер
                    th Адрес
                    th Заказчик
                    th Телефон
                    th Примечание
            tbody(each='{ item in items }')
                tr(bgcolor="#FFFFE0")
                    td(style="font-weight:bold" colspan="6" align="center")
                        | { item.weekday } - { item.date }
                tr(each='{ event in item.events }' bgcolor='{ event.color }' onclick='{ rowClick }')
                    th { event.time }
                    th { event.order }
                    th { event.address }
                    th { event.name }
                    th { event.phone }
                    th { event.note }

            loader(if='{ loader }')

    style(scoped).
        th {
            font-weight: normal;
        }

    script(type='text/babel').

        var self = this

        self.loader = false
        self.items = []
        self.startDate = (new Date()).toLocaleDateString()
        self.isSelected = false

        self.handlers = {
            block() {
                self.saveBusy(true)
            },
            unBlock() {
                self.saveBusy(false)
            }
        }

        self.saveBusy = (isBusy) => {
            let params = { events: [] };
            self.items.forEach(function(item) {
                item.events.forEach(function(event) {
                    if (event.selected && (event.busy != isBusy)) {
                        event.busy = isBusy
                        params.events.push(event)
                    }
                })
            })
            API.request({
                object: 'ScheduleEvent',
                method: 'Save',
                data: params,
                success() {
                    self.reload()
                }
            })
        }

        self.reload = () => {

            let params = {
                idSchedule: self.idSchedule
            }
            self.loader = true
            self.update()

            API.request({
                object: 'ScheduleEvent',
                method: 'Fetch',
                data: params,
                success(response) {
                    self.items = response.items
                    self.update()
                },
                error() {

                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        function setEventSelected (event) {
            event.color = "#C5CAE9"
            event.selected = true
        }

        function setEventUnselected (event) {
            if (event.selected)
                event.color = event.primaryColor
            event.selected = false
        }

        function selectOneEvent (event) {
            self.items.forEach(function (item) {
                item.events.forEach(function(event) {
                    setEventUnselected(event)
                })
            })
            setEventSelected(event)
        }

        function selectEvents (event) {
            if (event.selected)
                setEventUnselected(event)
            else
                setEventSelected(event)
        }

        self.selectRangeEvents = function (start, end) {
            let doSelect = false
            let isFinish = false
            if (start.index > end.index)
                [start, end] = [end, start]
            self.items.forEach(function(item) {
                item.events.forEach(function(event) {
                    if (start == event)
                        doSelect = true
                    if (doSelect)
                        setEventSelected(event)
                    if (end == event) {
                        isFinish = true
                        doSelect = false
                        return true
                    }
                })
                if (isFinish)
                    return true
            })
            self.update()
        }

        var lastSelectedEvent = null
        self.rowClick = function (e) {
            var event = e.item.event

            var currentSelectedEvent = event

            var currentClick = Date.now()
            var clickLength = currentClick - this.__lastClick__

            if (clickLength < 300 && clickLength > 0 && !e.ctrlKey && !e.metaKey && !e.shiftKey) {
                currentClick = 0
                doubleClick(e)
            }

            if (!e.shiftKey) {
                if (!e.ctrlKey && !e.metaKey)
                    selectOneEvent(event)
                else
                    selectEvents(event)
            } else
                if (lastSelectedEvent)
                    self.selectRangeEvents(lastSelectedEvent, currentSelectedEvent)

            if (!e.shiftKey)
                lastSelectedEvent = currentSelectedEvent

            self.isSelected = false
            self.items.forEach(function(item) {
                item.events.forEach(function(event) {
                    self.isSelected |= event.selected
                    if (self.isSelected)
                        return true;
                })
                if (self.isSelected)
                    return true;
            })

            this.__lastClick__ = currentClick
        }

        observable.on('schedule-events-reload', idSchedule => {
            self.idSchedule = idSchedule
            self.reload()
        })

        self.on('mount', () => {
            self.idSchedule = opts.id
            self.reload()
        })

