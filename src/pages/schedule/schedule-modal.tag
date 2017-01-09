| import './schedule.tag'

schedule-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title График услуг
        #{'yield'}(to="body")
            loader(if='{ loader }')
            virtual(hide='{ loader }')
                .schedule-list
                    .schedule-item(each='{ item in items }')
                        .schedule-item-name
                            | { item.shortDate }
                        .time-list
                            .time-item.disabled(data-id='')
                                label
                                    span 11:00
                            .time-item.disabled(data-id='')
                                label
                                    span 15:00
                            .time-item(data-id='597f5d5830ce87e5006079e4c0b5022f')
                                label
                                    input(type='radio', name='time', value='18:00')
                                    span 18:00


        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    style(scoped).
        .schedule-list {padding:15px; border:1px solid #e44533;}
        .schedule-item {display:inline-block; margin:5px;}
        .schedule-item-name {padding:5px 10px;}
        .time-item {padding:5px 10px; text-align:center;}
        .time-item.disabled {opacity:.5; text-align:center;}
        .time-item input {display:none;}
        .time-item.selected {background:#e44533;}
        .time-item:not(.disabled):hover {background:#f19a90;}

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.loader = true
            modal.items = []
            self.update()

            API.request({
                object: 'Schedule',
                method: 'Fetch',
                success(response) {
                    modal.items = response.items
                },
                error() {

                },
                complete() {
                    modal.loader = false
                    self.update()
                }
            })
        })


