person-pet-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Домашнее животное
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Фото
                                .well.well-sm
                                    image-select(name='imagePath', alt='0', size='256', value='{ item.imagePath }')
                        .col-md-6
                            .form-group
                                label.control-label Имя
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                            .form-group
                                label.control-label Вид животного
                                select.form-control(name='idPet', value='{ item.idPet }')
                                    option(each='{ pets }', value='{ id }',
                                    selected='{ id == item.idPet || !item.idPet }', no-reorder) { name }
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Дата рождения
                                datetime-picker.form-control(name='birthday',
                                    format='DD.MM.YYYY', value='{ item.birthday }', icon='glyphicon glyphicon-calendar')
                        .col-md-6
                            .form-group
                                label.control-label Вес (гр.)
                                input.form-control(name='weight', type='number', min='0', step='0.01', value='{ item.weight }')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.loader = true
            modal.error = false
            if (opts.pet)
                modal.item = opts.pet;
            else modal.item = {}
            modal.cols = [
                {name: "name", value: "Наименование"}
            ]
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty'
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {
                    ...modal.error,
                    ...modal.validation.validate(
                        modal.item,
                        modal.rules,
                        name
                        )
                    }
            }

            API.request({
                object: 'Pet',
                method: 'Fetch',
                success(response) {
                    modal.pets = response.items
                },
                complete() {
                    modal.loader = false
                    modal.update()
                }
            })
        })
