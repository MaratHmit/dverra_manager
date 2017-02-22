| import 'pages/schedule/schedule-events.tag'

schedule
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ schedules }', class='{ active: id == idSchedule }')
            a(href='#schedule/{ id }')
                span { name }

    .column(if='{ idSchedule  }')
        schedule-events(id='{ idSchedule }')

    script(type='text/babel').
        var self = this

        var route = riot.route.create()

        self.loadSchedules = () => {
           API.request({
               object: 'Schedule',
                method: 'Fetch',
                success(response) {
                    self.schedules = response.items
                    if (self.schedules.length) {
                        self.idSchedule = self.schedules[0].id
                        self.update()
                    }
                }
            })
        }

        route('/schedule', () => {
            self.notFound = false
            self.update()
        })

        route('/schedule/([0-9]+)', idSchedule => {
            self.notFound = false
            self.idSchedule = idSchedule
            self.update()
            observable.trigger('schedule-events-reload', idSchedule)
        })

        self.on('mount', function () {
            self.loadSchedules()
            riot.route.exec()
        })
