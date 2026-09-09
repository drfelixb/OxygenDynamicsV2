import unittest
import numpy as np
from verify_surge_local_onset import estimate
from verify_surge_onset_trace_panel import envelope, diagnostics, summary, compare


class TracePanelTests(unittest.TestCase):
    def test_available_context_recovers_ramp_after_neighbor(self):
        x=100+np.maximum(0,np.arange(1,201)-100);b=np.zeros(200,bool);b[74]=True
        self.assertEqual(estimate(x,120,150,b)['Status'],'overlapping_detection_in_fit')
        r=estimate(x,120,150,b,'available');self.assertEqual(r['OnsetFrame'],101);self.assertEqual(r['FitStartFrame'],76)

    def test_no_baseline_no_rescue(self):
        x=100+np.maximum(0,np.arange(1,201)-100);b=np.zeros(200,bool);b[109]=True
        r=estimate(x,120,150,b,'available');self.assertEqual(r['Status'],'insufficient_clean_context')
        self.assertTrue(np.isnan(r['ProvisionalAmplitude']))

    def test_recording_edge_context(self):
        x=100+np.maximum(0,np.arange(1,101)-30);r=estimate(x,50,70,np.zeros(100,bool),'available')
        self.assertEqual(r['OnsetFrame'],31);self.assertEqual(r['FitStartFrame'],1)

    def test_pulse_support_and_shape(self):
        for shape in ('linear','sine_squared'):
            e=envelope(150,51,15,shape)
            self.assertEqual(np.flatnonzero(e)[0]+1,51);self.assertTrue(np.all(e[64:85]==1))
            self.assertTrue(np.all(e[99:]==0));self.assertTrue(np.all((e>=0)&(e<=1)))
        self.assertAlmostEqual(envelope(150,51,15,'linear')[50],1/15)
        self.assertAlmostEqual(envelope(150,51,15,'sine_squared')[50],np.sin(np.pi/30)**2)

    def test_baseline_effect_denominator(self):
        x=np.ones(100)*100;e=envelope(100,51,15,'linear');y=x*(1+.2*e)
        r=dict(Status='resolved',OnsetFrame=60);control=dict(Status='resolved',OnsetFrame=60)
        d=diagnostics(x,y,e,70,85,51,r,control)
        bx=np.mean(x[39:59]);by=np.mean(y[39:59]);peak=np.max(y[69:85])
        self.assertAlmostEqual(d['BaselineEffectPP'],100*(peak/by-peak/bx))
        self.assertEqual(d['PositiveBaselineFrames'],9);self.assertEqual(d['OnsetErrorSec'],9)
        self.assertFalse(d['WithinFiveSec']);self.assertTrue(d['SameOnsetAsControl'])

    def test_unresolved_is_not_a_zero_error(self):
        x=np.ones(100)*100;e=envelope(100,51,15,'linear')
        d=diagnostics(x,x*(1+.2*e),e,70,85,51,dict(Status='insufficient_improvement'),dict(Status='resolved',OnsetFrame=60))
        self.assertTrue(np.isnan(d['OnsetErrorSec']));self.assertFalse(d['WithinFiveSec'])

    def test_summary_preserves_denominators(self):
        good=dict(Context='fixed',Constructible='1',Status='resolved',WithinFiveSec='1',BaselineUnderOnePercent='1',
                  BaselineStatus='provisional_valid',SameOnsetAsControl='0',OnsetErrorSec='2',ProposedBaselineImposedFraction='0',BaselineEffectPP='0')
        missing=dict(good,Status='insufficient_improvement',WithinFiveSec='0',BaselineUnderOnePercent='0')
        excluded=dict(missing,Constructible='0',Status='construction_unavailable')
        r=summary([good,missing,excluded],['Context'])[0]
        self.assertEqual((r['Planned'],r['Constructible'],r['Resolved']),(3,2,1))
        self.assertEqual(r['WithinFiveSecFractionAll'],.5);self.assertEqual(r['WithinFiveSecFractionResolved'],1)

    def test_changed_flag_fails_with_optimization(self):
        with self.assertRaises(ValueError):compare(dict(Constructible='0'),dict(Constructible=True))


if __name__=='__main__':unittest.main()
