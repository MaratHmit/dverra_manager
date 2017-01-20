order-status-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Статус заказа
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Новый статус заказа
                    select.form-control(name='idStatus', value='{ item.idStatus }')
                        option(each='{ statuses }', value='{ id }',
                            selected='{ id == item.idStatus }', no-reorder) { name }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            let statuses = opts.statuses
            modal.item = {
                idStatus: opts.idStatus
            }
            let curStatus
            statuses.forEach((status) => {
                if (status.id == modal.item.idStatus) {
                    curStatus = status
                    return true
                }
            })
            modal.statuses = statuses.filter((status) => {
                return (status.id != 6) && (status.sort > curStatus.sort)
            })
            if (modal.statuses.length)
                modal.item.idStatus = modal.statuses[0].id

            modal.mixin('change')

        })
