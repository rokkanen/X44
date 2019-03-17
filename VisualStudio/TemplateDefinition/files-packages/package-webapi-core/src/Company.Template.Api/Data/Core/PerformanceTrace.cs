namespace Company.Template.Data
{
    using log4net;
    using System;
    using System.Diagnostics;

    public class PerformanceTrace : IDisposable
    {
        private Stopwatch stopwatch = new Stopwatch();
        private ILog log;
        private string title;

        public PerformanceTrace(string title, ILog logger)
        {
            stopwatch.Start();

            this.log = logger;
            this.title = title;

            if ((this.log != null) && this.log.IsDebugEnabled)
            {
                log.Debug(string.Format("Start {0}", this.title));
            }

        }

        public void Dispose()
        {
            stopwatch.Stop();

            if ((this.log != null) && this.log.IsDebugEnabled)
            {
                log.Debug(string.Format("End {0} - elapsed time = {1}ms", this.title, stopwatch.ElapsedMilliseconds));
            }
        }
    }
}
