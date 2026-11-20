import unittest
import numpy as np
from verify_surge_pulse_onset import fit_batch, pulse, selected_template
from verify_surge_onset_trace_panel import envelope


class PulseFitTests(unittest.TestCase):
    def test_noiseless_short_late_pulse(self):
        x=100*(1+.2*envelope(240,95,5,'sine_squared'))
        r=fit_batch(x[None,:],120,180,np.zeros(240,bool))[0]
        self.assertEqual(r['Status'],'resolved');self.assertEqual(r['OnsetFrame'],95)

    def test_no_flat_or_linear_pulse(self):
        f=np.arange(1,201);x=np.array([np.ones(200)*100,100+.1*f,200-np.maximum(0,f-100)])
        self.assertTrue(all(r['Status']!='resolved' for r in fit_batch(x,120,150,np.zeros(200,bool))))

    def test_context_exclusion(self):
        x=100*(1+.2*envelope(200,101,15,'linear'));b=np.zeros(200,bool);b[74]=True
        r=fit_batch(x[None,:],120,150,b)[0];self.assertEqual(r['FitStartFrame'],76);self.assertEqual(r['OnsetFrame'],101)
        b[109]=True;self.assertEqual(fit_batch(x[None,:],120,150,b)[0]['Status'],'insufficient_clean_context')

    def test_gain_and_missing_peak(self):
        x=100*(1+.2*envelope(200,101,15,'linear'));y=np.array([x,5*x,x]);y[2,144]=np.nan
        r=fit_batch(y,120,150,np.zeros(200,bool));self.assertEqual(r[0]['OnsetFrame'],r[1]['OnsetFrame'])
        self.assertAlmostEqual(r[0]['ProvisionalAmplitude'],r[1]['ProvisionalAmplitude'])
        self.assertEqual(r[2]['BaselineStatus'],'missing_native_signal');self.assertTrue(np.isnan(r[2]['ProvisionalAmplitude']))

    def test_template_matches_generator(self):
        for shape,s in [('linear',1),('sine_squared',2)]:
            actual=pulse(np.arange(1,201)-100,np.array([[15,20,15,s]]))[:,0]
            np.testing.assert_allclose(actual,envelope(200,101,15,shape),atol=1e-14)

    def test_spurious_template_fails_under_optimization(self):
        with self.assertRaises(ValueError):selected_template(dict(ScoreImprovement='nan',TemplateShape='linear'),np.ones(200))


if __name__=='__main__':unittest.main()
