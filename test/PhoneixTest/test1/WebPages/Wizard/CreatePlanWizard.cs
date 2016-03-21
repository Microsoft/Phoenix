﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Phoenix.Test.UI.Framework.WebPages
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;
    using OpenQA.Selenium;
    using OpenQA.Selenium.Support.PageObjects;
    using Phoenix.Test.UI.Framework.Controls;
    using Phoenix.Test.UI.Framework.Logging;
    using Phoenix.Test.UI.Framework.WebPages;
    using Phoenix.Test.Data;

    class CreatePlanWizard : Page
    {
        [FindsBy(How = How.ClassName, Using = "wizard-button-next")]
        private HtmlButton next { get; set; }

        [FindsBy(How = How.ClassName, Using = "wizard-button-back")]
        private HtmlButton back { get; set; }

        // step 1
        [FindsBy(How = How.Name, Using = "planEntityFriendlyName")]
        private HtmlCheckBox planEntityFriendlyName { get; set; }

        // step 2
        private HtmlCheckBox sqlServers { get; set; }
        private HtmlCheckBox mySqlServers { get; set; }
        private HtmlCheckBox cmpWapExtension { get; set; }

        // step 3



        public CreatePlanWizard(IWebDriver browser)
            : base(browser)
        {
        }

        public override HtmlControl VerifyPageElement
        {
            get { return next; }
        }

        public void GoNext()
        {
            this.next.Click();
            System.Threading.Thread.Sleep(500);
        }

        public void Complete()
        {
            this.next.Click();
        }

        public void GoBack()
        {
            this.back.Click();
        }

        public void Step1(CreatePlanData data)
        {
            Log.Information("Input Plan Friendly Name.");
            this.planEntityFriendlyName.SetText(data.planName);
        }

        public void Step2(CreatePlanData data)
        {
            // The checkbox will NOT be created until step2 show up, so we have to create it here.
            this.cmpWapExtension = new HtmlCheckBox(this, By.Name("CmpWapExtension"));
            this.cmpWapExtension.Check();
        }

        public void Step3(CreatePlanData data)
        {
        }
    }
}
