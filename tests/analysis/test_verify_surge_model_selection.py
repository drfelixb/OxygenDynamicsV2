import unittest
import numpy as np
from verify_surge_model_selection import select, unseen


def model(score,k):
    return dict(Status='resolved',ScoreImprovement=score,OnsetFrame=k,FitStartFrame=60,FitEndFrame=124,
        ProfileStartFrame=k-1,ProfileEndFrame=k+1,BaselineStartFrame=k-20,BaselineEndFrame=k-1,
        BaselineMean=100,ProvisionalAmplitude=.2,BaselineStatus='provisional_valid')


class SelectionTests(unittest.TestCase):
    def test_disagreement_remains_missing(self):
        r=select(model(30,100),model(29,110));self.assertEqual(r['Status'],'model_disagreement');self.assertTrue(np.isnan(r['ProvisionalAmplitude']))

    def test_best_unresolved_cannot_be_rescued(self):
        a=model(30,100);a['Status']='broad_profile_unresolved'
        self.assertEqual(select(a,model(20,101))['Status'],'best_model_unresolved')

    def test_near_unresolved_veto_only(self):
        a=model(30,100);b=model(29,101);b['Status']='search_boundary_unresolved'
        self.assertEqual(select(a,b)['Status'],'model_uncertainty');b['ScoreImprovement']=20
        self.assertEqual(select(a,b)['Status'],'resolved')

    def test_penalty_tie_and_amplitude(self):
        self.assertEqual(select(model(11,100),model(10,101))['Status'],'no_model_evidence')
        a=model(30,100);b=model(30,101);b['ProvisionalAmplitude']=.9
        self.assertEqual(select(a,b)['SelectedModel'],'rising');self.assertEqual(select(a,b)['ProvisionalAmplitude'],.2)

    def test_profile_union_and_missing_reference(self):
        a=model(30,100);b=model(29,104);a['ProfileStartFrame']=95;b['ProfileEndFrame']=108
        self.assertEqual(select(a,b)['Status'],'model_uncertainty')
        a=model(30,100);a['ProvisionalAmplitude']=np.nan;a['BaselineStatus']='missing_native_signal'
        self.assertTrue(np.isnan(select(a,model(20,101))['ProvisionalAmplitude']))

    def test_context_mismatch_fails_optimized(self):
        a=model(30,100);b=model(29,101);b['FitStartFrame']=61
        with self.assertRaises(ValueError):select(a,b)

    def test_unseen_waveform_support(self):
        for shape in ('gamma','exponential','quadratic'):
            e,last=unseen(600,101,23,shape)
            self.assertEqual(np.flatnonzero(e)[0]+1,101);self.assertTrue(np.all((e>=0)&(e<=1)))
            self.assertTrue(np.all(e[last:]==0));self.assertAlmostEqual(e[122],1)

    def test_nonlibrary_rise_and_truncation(self):
        e,last=unseen(120,101,23,'exponential');self.assertGreater(last,120)
        q,_=unseen(300,101,7,'quadratic');self.assertAlmostEqual(q[100],1/49);self.assertEqual(q[131],0)


if __name__=='__main__':unittest.main()
