| import './schedule.tag'

schedule-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title График услуг
        #{'yield'}(to="body")
            loader(if='{ loader }')
            virtual(hide='{ loader }')
                .btn-group.schedule-list(role="group")
                    .schedule-item(each='{ item in items }')
                        .schedule-item-name
                            | { item.shortDate }
                        .time-list
                            span.time-item(each='{ event in item.events }')
                                button(if='{ !event.selected }',
                                    disabled='{ event.busy }', onclick='{ selectTime }', data-index='{ event.index }') { event.time }
                                button.selected(if='{ event.selected }',
                                    disabled='{ event.busy }', onclick='{ unSelectTime }', data-index='{ event.index }') { event.time }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed', disabled='{ !isSelected }') Выбрать

    style(scoped).
        .schedule-list {padding:15px; border:1px solid #e44533;}
        .schedule-item {display:inline-block; margin:5px;}
        .time-item button{padding:5px 10px; text-align:center;}
        .time-item button:disabled {opacity:.5; text-align:center;}
        .time-item button.selected {background:dodgerblue; color: white}
        .time-item button:not(:disabled):hover {background:forestgreen; color: white}

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            let serviceDate = opts.serviceDate
            modal.loader = true
            modal.isSelected = false
            modal.selectedEvent = null
            modal.items = []
            self.update()

            API.request({
                object: 'Schedule',
                method: 'Fetch',
                success(response) {
                    modal.items = response.items
                    if (serviceDate) {
                        let date, time
                        [date, time] = serviceDate.split(" ")
                        modal.items.forEach((item) => {
                            item.events.forEach((event) => {
                                if (event.date == date && event.time == time) {
                                    modal.selectedEvent = event
                                    modal.selectedEvent.selected = true
                                    modal.isSelected = true
                                    return true
                                }
                                if (modal.selectedEvent)
                                    return true
                            })
                        })
                    }

                },
                error() {

                },
                complete() {
                    modal.loader = false
                    self.update()
                }
            })

            modal.selectTime = (e) => {
                let event = e.item.event
                modal.items.forEach((item) => { item.events.forEach((event) => { event.selected = false }) })
                event.selected = true
                modal.isSelected = true
                modal.selectedEvent = event
                self.update()
            }
            modal.unSelectTime = (e) => {
                let event = e.item.event
                event.selected = false
                self.update()
            }
        })


