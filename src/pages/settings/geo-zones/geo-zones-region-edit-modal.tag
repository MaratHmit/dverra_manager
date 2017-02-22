geo-zones-region-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { 'Регион/город' }
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.region }')
                            label.control-label Регион
                            select.form-control(name='region', value='{ item.region }')
                                option(value='Москва') Москва
                                option(value='Московская область') Московская область
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.city }')
                            label.control-label Город
                            input.form-control(name='city', value='{ item.city }')
                            .help-block { error.city }
                .row
                    .col-md-12
                        .form-group
                            label.control-label Округ
                            input.form-control(name='area', value='{ item.area }')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

        script(type='text/babel').
            var self = this

            self.on('mount', () => {
                let modal = self.tags['bs-modal']

                modal.error = false
                modal.isNew = opts.isNew || false
                modal.item = opts.item || {}
                modal.mixin('validation')
                modal.mixin('change')

                if (!modal.item.region)
                    modal.item.region = "Москва"

                modal.rules = {
                    region: 'empty',
                    city: 'empty',
                }

                modal.afterChange = e => {
                    let name = e.target.name
                    delete modal.error[name]
                    modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
                }
            })
